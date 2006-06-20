From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [RFC] [patch 0/6] [Network namespace] introduction
Date: Tue, 20 Jun 2006 22:25:11 +0100
Message-ID: <20060620212511.GW27946@ftp.linux.org.uk>
References: <20060609210202.215291000@localhost.localdomain> <20060618184734.GB27946@ftp.linux.org.uk> <449866E7.4050508@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751128AbWFTVZh@vger.kernel.org>
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Content-Disposition: inline
In-Reply-To: <449866E7.4050508@fr.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 20, 2006 at 11:21:43PM +0200, Daniel Lezcano wrote:
> Al Viro wrote:
> >On Fri, Jun 09, 2006 at 11:02:02PM +0200, dlezcano@fr.ibm.com wrote:
> >- renaming an interface in one "namespace" affects everyone.
> 
> Exact. If we ensure the interface can't be renamed if used in different 
> namespace, is it really a problem ?

You _still_ have a single namespace; look in /sys/class/net and you'll see.
