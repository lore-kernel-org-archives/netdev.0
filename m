From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: tx-switching module parameter
Date: Tue, 17 Apr 2012 13:22:09 +0300
Message-ID: <1334658129.12363.3.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1329401112-9542-1-git-send-email-ariele@broadcom.com>
 <20120216094936.3449e6ef@nehalam.linuxnetplumber.net>
 <1329417315.30697.3.camel@lb-tlvb-eilong.il.broadcom.com>
 <4F3D5B47.6030505@intel.com>
 <1329422255.30697.5.camel@lb-tlvb-eilong.il.broadcom.com>
 <4F8BA9FE.4010905@intel.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, "Stephen Hemminger" <shemminger@vyatta.com>,
	"Ariel Elior" <ariele@broadcom.com>, netdev@vger.kernel.org
To: "John Fastabend" <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4937 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752621Ab2DQKWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 06:22:23 -0400
In-Reply-To: <4F8BA9FE.4010905@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-04-15 at 22:11 -0700, John Fastabend wrote:
> On 2/16/2012 11:57 AM, Eilon Greenstein wrote:
> >>>> "Ariel Elior" <ariele@broadcom.com> wrote:
> >>>>
> >>>>> In 57712 and 578xx the tx-switching module parameter allows the user to control
> >>>>> whether outgoing traffic can be loopbacked into the device in case there is a
> >>>>> relevant client for the data using the same device for rx.
> 
> [...]
> 
> >>> But netdev is a great place to ask - are there other vendors out there
> >>> that requires this control over internal switching? If so, we can define
> >>> a new ethtool command. The alternative of using the ethtool private
> >>> flags seems just as inconvenient from administrators point of view and
> >>> also seem less appropriate since this configuration is more likely to be
> >>> the same for all PFs on the same machine.
> >>>
> 
> [...]
> 
> > OK, thanks John. Dave - please do not apply this patch. We need to look
> > at the alternatives suggested by John.
> > 
> > Thanks,
> > Eilon
> > 
> 
> Eilon, any progress with this? We need this to support VEPA modes in
> macvlan running over SR-IOV devices or other embedded switches. The
> problem being if the stacked device expects the packet to be sent
> to the reflexive relay on the switch in the SR-IOV case the embedded
> switch may not actually do this.

John, honestly, this is not at the top of the priority list for us right
now. If you would like to proceed, please do so - we will have to adopt
to what you suggest when we get back to this issue.

Thanks,
Eilon
