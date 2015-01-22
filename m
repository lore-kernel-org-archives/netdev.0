From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net 2/2] net: cls_bpf: fix auto generation of per list
 handles
Date: Thu, 22 Jan 2015 20:02:34 +0100
Message-ID: <54C1494A.5050205@redhat.com>
References: <1421919662-21066-1-git-send-email-dborkman@redhat.com> <1421919662-21066-3-git-send-email-dborkman@redhat.com> <CAADnVQLn2QXJaDvbvothBrKZTnPD1sGjh7ZNPuUG=MH3ZJTU4A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38145 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754321AbbAVTCm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 14:02:42 -0500
In-Reply-To: <CAADnVQLn2QXJaDvbvothBrKZTnPD1sGjh7ZNPuUG=MH3ZJTU4A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2015 07:52 PM, Alexei Starovoitov wrote:
...
> interesting bug. first time I'm looking at this bit and wondering
> why everyone copy pasting such hgenerator instead of using idr...

I think we should abstract these bits into a helper function. ;)
Hmm, looking into git history tree, hgenerator came later than
idr, so I presume the overhead of idr was not worth it.
