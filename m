From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [patch 7/11] net: Use bigrefs for net_device.refcount
Date: Tue, 13 Sep 2005 13:26:07 -0700 (PDT)
Message-ID: <20050913.132607.113443001.davem@davemloft.net>
References: <20050913155112.GB3570@localhost.localdomain>
	<20050913161012.GI3570@localhost.localdomain>
	<20050913092659.791bddec@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kiran@scalex86.org, akpm@osdl.org, linux-kernel@vger.kernel.org,
	dipankar@in.ibm.com, bharata@in.ibm.com, shai@scalex86.org,
	rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932456AbVIMU0N@vger.kernel.org>
To: shemminger@osdl.org
In-Reply-To: <20050913092659.791bddec@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 13 Sep 2005 09:26:59 -0700

> Since when is bringing a network device up/down performance critical?

The issue is the dev_get()'s that occur all over the place
to during packet transmit/receive, that's what they are
trying to address.

I'm still against all of these invasive NUMA changes to the
networking though, they are simply too ugly and special cased
to consider seriously.
