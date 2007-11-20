From: "Mike Frysinger" <vapier.adi@gmail.com>
Subject: Re: netconsole=y and rtl8139=m
Date: Tue, 20 Nov 2007 02:57:16 -0500
Message-ID: <8bd0f97a0711192357o3c3e66c3w97e08a2a96bac1e4@mail.gmail.com>
References: <Pine.LNX.4.64.0711200815220.32378@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Jan Engelhardt" <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:10892 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757407AbXKTH5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 02:57:17 -0500
Received: by wr-out-0506.google.com with SMTP id c49so996669wra
        for <netdev@vger.kernel.org>; Mon, 19 Nov 2007 23:57:17 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0711200815220.32378@fbirervta.pbzchgretzou.qr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov 20, 2007 2:17 AM, Jan Engelhardt <jengelh@computergmbh.de> wrote:
> I get this during boot:
>
> [   40.821740] netconsole: eth1 doesn't exist, aborting.
>
> Given that CONFIG_NETCONSOLE=y and CONFIG_8139TOO=m, I can imagine.
> Is there a way to get this working without making 8139TOO=y or
> NETCONSOLE=m?

i guess that depends on what your expectations are.  what do you think
would qualify as a fix ?  that netconsoles could get added/removed
dynamically based on network drivers being loaded/unloaded instead of
netconsole being set up just once at netconsole init time ?
-mike
