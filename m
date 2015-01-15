From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: non-OVS based vxlan config broken on 3.19-rc ?!
Date: Thu, 15 Jan 2015 15:25:29 +0200
Message-ID: <54B7BFC9.8070306@mellanox.com>
References: <54B688D9.8030101@mellanox.com>
	<20150114155208.GA24550@casper.infradead.org>
 <CAJ3xEMj+rjTmk2tbVCTMCp+7N0qwXBNf3JsbJEgh2qvq0jHmEg@mail.gmail.com>
 <54B7B086.7080208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: thomas Graf <tgraf@suug.ch>, tom Herbert <therbert@google.com>,
	"Jesse Gross" <jesse@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0061.outbound.protection.outlook.com ([157.56.112.61]:31911
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752582AbbAONkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 08:40:40 -0500
In-Reply-To: <54B7B086.7080208@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/15/2015 2:20 PM, Marcelo Ricardo Leitner wrote:
> Just tested your commands on two virtual machines running virtio (same 
> host), Linus' commit fb005c47f7b72edac50342b6af490af09854381b (which 
> is 3.19.0-rc4+) and it worked just fine for me. That is, ping went 
> through both ways without issues. I'll still try with net.git.. 

thanks for looking on that.

> Did you try dropwatch? If you add a neigh entry for the remote peer 
> and ping flood it, you may spot it on dropwatch. 

Will try it out, for the time being I managed to have an environment to 
test that fix I was working on recently...

Or.
