From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Implementing Dynamic Rerouting in Kernel
Date: Thu, 11 May 2017 09:22:59 -0700
Message-ID: <3b6e4d7b-0e35-5944-1200-6b0721afca82@gmail.com>
References: <CAEDnJmKWYeEwB=cBKd-cOL+hmxe0U6G7CQ8Mkwc_eP5CpJVmbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Ravish Kumar <ravishk2004@gmail.com>,
        Networking <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org, mst@redhat.com, Jason@zx2c4.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33136 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753288AbdEKQXH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:23:07 -0400
In-Reply-To: <CAEDnJmKWYeEwB=cBKd-cOL+hmxe0U6G7CQ8Mkwc_eP5CpJVmbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/2017 02:59 AM, Ravish Kumar wrote:
> Hi Experts,
> 
> Need expert advice for the one of the requirement Where in VPN
> solution we want to dynaically route the packets to different adapter.
> We will manage our own DNS cache and , based on DNS to IP lookup, we
> can redirect the packet either to Tun device or to a physical adapter.
> 
> Please suggest some design what i need to do.

What you are looking for can be done using ipset-dns from Jason:

https://git.zx2c4.com/ipset-dns/about/
-- 
Florian
