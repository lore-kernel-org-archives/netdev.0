From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH/RFC net-next 0/4] Allow use of rocker ports without bridging
Date: Mon, 13 Apr 2015 07:59:21 -0700
Message-ID: <CAE4R7bA3hsRBOY9+YZXQ8b-7T_DwgzcrAM=wzYj+cyyWVkbRHQ@mail.gmail.com>
References: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:33151 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbbDMO7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:59:22 -0400
Received: by qgdy78 with SMTP id y78so1922156qgd.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 07:59:21 -0700 (PDT)
In-Reply-To: <1428907677-27204-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 12, 2015 at 11:47 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> Hi,
>
> this short series attempts to allow rocker ports to be used when they
> are not attached to a bridge. It attempts to make use of flow entries
> in a rocker switch where appropriate and otherwise forwards packets up
> to the kernel for processing.

Hi Simon,

Unbridged ports should be working now with current driver/device.  I
wonder if you have an older qemu rocker device?  Use master branch of
https://github.com/scottfeldman/qemu-rocker.git.

My test setup is to IPv4 ping two hosts from two different ports.
Something like:

sw1:sw1p1:11.0.0.1/24 <----------------> h1:eth1:11.0.0.2/24
sw1:sw1p2:12.0.0.1/24 <----------------> h2:eth1:12.0.0.2/24

ARP and ping work fine.  What is your test setup?  I haven't spent a
lot of time on unbridged port testing, since major focus has been on
offloading bridge L2 and L3.

-scott
