From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: WCONF, netlink based WE replacement.
Date: Fri, 13 Jan 2006 09:55:33 -0800
Message-ID: <20060113095533.5d5df015@dxpl.pdx.osdl.net>
References: <200601121824.02892.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422755AbWAMRzn@vger.kernel.org>
To: Michael Buesch <mbuesch@freenet.de>
In-Reply-To: <200601121824.02892.mbuesch@freenet.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jan 2006 18:24:02 +0100
Michael Buesch <mbuesch@freenet.de> wrote:

> This is an attempt to rewrite the Wireless Extensions
> userspace API, using netlink sockets.
> There should also be a notification API, to inform
> userspace for changes (config changes, state changes, etc).
> It is not implemented, yet.
> 
> This is against the devicescape stack.
> This patch is not to be used, but only to be commented on. ;)
> Basically I would like comments on the API definition
> in wconf.h
> 

1. You will need more documentation, eventually in Documentation directory.

2. Is there 1:1 relationship between ieee80211_device and net_device or 
    N net_devices per ieee80211_device?

3. Don't put a version number on the protocol messages. The way to
   us netlink is to us Type Length Variable structures. And write the
   code to ignore unknown types.  Once you decide on a particular Type
   then it has to be frozen for ABI compatibility.  The version numbering
   in the WE API is part of the problem

4. What about non-ieee80211 devices? With the growth of (mostly proprietary)
   cell phone carrier wireless, you don't want to shut out that.
