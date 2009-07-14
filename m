From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Tell linkwatch about new interfaces
Date: Tue, 14 Jul 2009 11:33:48 -0700 (PDT)
Message-ID: <20090714.113348.155881037.davem@davemloft.net>
References: <cb0375e10904010840n1543a890w9039465d0f80ffcc@mail.gmail.com>
	<20090404.170539.148727646.davem@davemloft.net>
	<ce0170d90907141017h732c2cd7ja5990303093b6edd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amluto@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: eeeesti@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755942AbZGNSdq@vger.kernel.org>
In-Reply-To: <ce0170d90907141017h732c2cd7ja5990303093b6edd@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergio Luis <eeeesti@gmail.com>
Date: Tue, 14 Jul 2009 14:17:21 -0300

> is this patch incorrect, though? with the linkwatch_fire_event() call,
> the rfc2863 operstate will be set for everyone at device register
> time.

The issue is dumb drivers that do not manage their link state
at all.  We want them to always have their links up, from the
moment they are registered.

This is especially important for virtual devices.
