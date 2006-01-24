From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [BUG] sky2 broken for Yukon PCI-E Gigabit Ethernet Controller
 11ab:4362 (rev 19)
Date: Tue, 24 Jan 2006 10:43:57 +0100
Message-ID: <43D5F6DD.70702@t-online.de>
References: <43D1C99E.2000506@t-online.de>	<20060123101538.14d21bf4@dxpl.pdx.osdl.net>	<43D52C69.5090707@t-online.de> <20060123112751.2e3f1b15@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030425AbWAXJoF@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060123112751.2e3f1b15@dxpl.pdx.osdl.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger schrieb:

>Could you try turning off rx checksumming (with ethtool).
>	ethtool -K eth0 rx off
>
>There probably still are (generic) bugs in the netfilter code for CHECKSUM_HW
>socket buffers.
>
>  
>
"ethtool -K eth0 rx off" does cure my problem with sky2.

Anybody is invited to send patches as the problem is 100% reproducible here.

cu,
 Knut
