From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Fri, 12 Oct 2007 15:48:59 +0200
Message-ID: <470F7B4B.2010609@trash.net>
References: <200710120031.42805.a1426z@gawab.com> <Pine.LNX.4.64.0710121449370.23981@fbirervta.pbzchgretzou.qr> <200710121630.29151.a1426z@gawab.com> <Pine.LNX.4.64.0710121533360.23981@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Al Boldi <a1426z@gawab.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758406AbXJLNty@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0710121533360.23981@fbirervta.pbzchgretzou.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Oct 12 2007 16:30, Al Boldi wrote:
>>>>
>>>>With the existence of the mangle table, how useful is the filter table?
>>>
>>>A similar discussion was back in March 2007.
>>>http://marc.info/?l=netfilter-devel&m=117394977210823&w=2
>>>http://marc.info/?l=netfilter-devel&m=117400063907706&w=2
>>>
>>>in the end, my proposal was something like
>>>http://jengelh.hopto.org/GFX0/nf_proposal2.svg
>>
>>Any chance you could publish this as something readable like text/html?
> 
> 
> Like, image/png?
> http://jengelh.hopto.org/GFX0/nf_proposal2.png


The netlink based iptables successor I'm currently working on allows to
dynamically create tables with user-specified priorities and "built-in"
chains. The only built-in tables will be those that need extra
processing (mangle/nat). So it should be possible to set up tables
basically any way you desire.
