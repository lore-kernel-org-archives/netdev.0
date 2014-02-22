From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Does CHECKSUM_COMPLETE work at all?
Date: Sat, 22 Feb 2014 13:42:28 +0100
Message-ID: <53089B34.5060504@redhat.com>
References: <CA+mtBx8safaPpcntjqT+eUQBDEOxJBoVf-a9djX_qgYsSdACeA@mail.gmail.com> <CBA48B605613B640864883107238931C0F9077@nice.asicdesigners.com> <CA+mtBx97w02+6iVcDxsGh4-TzsnZcjRv0+jyD=qGrCPfcWNDqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dimitrios Michailidis <dm@chelsio.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33668 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211AbaBVMmh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Feb 2014 07:42:37 -0500
In-Reply-To: <CA+mtBx97w02+6iVcDxsGh4-TzsnZcjRv0+jyD=qGrCPfcWNDqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2014 04:08 AM, Tom Herbert wrote:
...
> Well..., I started trying to fix the UDP encapsulation code which we
> agreed was broken for checksums. This also entails fixing the new UDP
> GRO code to deal with checksums correctly when going through protocol
> layers. But, just looking at CHECKSUM_COMPLETE it seems like it's
> fundamentally broken even without encapsulation. Between GRO and HW
> checksums, it seems like we have a pretty big mess! :-)

Seems so, e.g. d97c00a32198 ("vxlan: fix receive checksum handling")
had similar issues in that regard; maybe because there seems to be
different consensus among drivers on setting CHECKSUM_COMPLETE?
