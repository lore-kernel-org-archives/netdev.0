From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] colons are invalid characters in netdev names
Date: Tue, 17 Feb 2015 19:28:03 -0600
Message-ID: <20150217192803.21a63afd@uryu.home.lan>
References: <1424214942-17581-1-git-send-email-mthode@mthode.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matthew Thode <mthode@mthode.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424214942-17581-1-git-send-email-mthode@mthode.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Feb 2015 17:15:42 -0600
Matthew Thode <mthode@mthode.org> wrote:

> colons are used as a separator in netdev device lookup in dev_ioctl.c
> 
> Specific functions are SIOCGIFTXQLEN SIOCETHTOOL SIOCSIFNAME
> 
> Signed-off-by: Matthew Thode <mthode@mthode.org>

What is the exact sequence that causes the problem?
SIOCSIFNAME already strips of colon.
