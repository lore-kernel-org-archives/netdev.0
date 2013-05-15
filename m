From: "Holger Hoffstaette" <holger.hoffstaette@googlemail.com>
Subject: Re: r8169 on 3.8.13, 3.9.2, 3.10-rc1, was Re: [ 00/73] 3.8.13-stable review
Date: Wed, 15 May 2013 10:31:50 +0200
Message-ID: <pan.2013.05.15.08.31.40.496197@googlemail.com>
References: <20130509222757.917088509@linuxfoundation.org> <pan.2013.05.10.10.54.26.943195@googlemail.com> <20130515000715.GA20099@milliways>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 May 2013 01:07:15 +0100, Ken Moffat wrote:

>  Cc'ing to netdev because I don't think this has had a response, and
> I care because I *might* be seeing the same problem on both 3.9.2 and
> 3.10-rc1, but my take on the problem is slightly different [ details after
> Holger's posting ]

I later isolated the regression to tx offloading, which allows one to
reproduce the problem on the fly (enable: b0rken internets, disable: all
fine). So unless you have tx offloading enabled then whatever you are
seeing has likely nothing to do with *this* problem.

Francois posted a patch to -netdev which I am running as we speak, and the
problem seems fixed for me; tx offloading (in adition to rx/gro) works
again, with no side effects. Please help test!

-h
