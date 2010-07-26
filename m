From: "Loke, Chetan" <Chetan.Loke-Wi0MfyythtRWk0Htik3J/w@public.gmane.org>
Subject: Re: tcpdump <-> FCoE support
Date: Mon, 26 Jul 2010 14:27:56 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90C6F54AD@nsmail.netscout.com>
References: <D3F292ADF945FB49B35E96C94C2061B90C6F53AE@nsmail.netscout.com>
	<4C4DCCA6.5060206@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
To: "Joe Eykholt" <jeykholt-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <4C4DCCA6.5060206-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Joe Eykholt [mailto:jeykholt-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org]
> 
> Good question.  There's no effort in progress that I know of.
> I find wireshark very handy and do tend to capture with tcpdump -w
> and then read the file with wireshark.  tshark is handy if you
> want a CLI mode.
> 
> If tcpdump interpreted FCoE frames, then we would want FC, FC-ELS,
> and FCP.  Does it already dissect any SCSI frames (e.g., iSCSI)?
> I'm not sure how much work it would be, but given tshark
> is around, I don't think it's that important.
> 
Oki thanks. I'll play with tshark. If tshark handles the FIP/FC
discovery business then that's perfect. I don't have a FCoE target
configured yet. I just sent a raw fcoe-frame to check how tcpdump
responds.

> It could at least be changed to print out FCoE instead of 0x8906,
> and FIP instead of 0x8914.
> 
Agreed.


> 	Joe
Chetan Loke
