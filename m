From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Fri, 25 Nov 2011 14:31:12 -0600
Message-ID: <20111125203111.GC26692@elie.hsd1.il.comcast.net>
References: <4E7F4D45.7040902@wolke7.net>
 <1316978632.4122.103.camel@deadeye>
 <4E82C0B5.1050902@wolke7.net>
 <1317254171.4068.12.camel@deadeye>
 <20111124044137.GA18262@elie.hsd1.il.comcast.net>
 <4ECFE7A7.5070300@wolke7.net>
 <20111125201936.GA26692@elie.hsd1.il.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org,
	Armin Kazmi <armin.kazmi@tu-dortmund.de>,
	Gerd <booster@wolke7.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:35573 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752092Ab1KYUbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 15:31:16 -0500
Content-Disposition: inline
In-Reply-To: <20111125201936.GA26692@elie.hsd1.il.comcast.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jonathan Nieder wrote:

> From another log, using a kernel without pae support:
>
>> [  844.056012] BUG: soft lockup - CPU#0 stuck for 23s! [smbd:2770]
> [...]
>> [  872.056011] BUG: soft lockup - CPU#0 stuck for 23s! [smbd:2770]
> [...]
>> [  900.056011] BUG: soft lockup - CPU#0 stuck for 23s! [smbd:2770]

What I meant is a kernel without SMP support (it lacks PAE, too, but
that's less relevant).  Description:

 http://packages.debian.org/sid/linux-image-3.1.0-1-486

.configs for the two kernels mentioned:

 http://alioth.debian.org/~jrnieder-guest/temp/config-3.1.0-1-686-pae
 http://alioth.debian.org/~jrnieder-guest/temp/config-3.1.0-1-486

Sorry for the lack of clarity.
