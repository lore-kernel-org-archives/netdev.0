From: Dana Lacoste <dana.lacoste@peregrine.com>
Subject: Re: route cache and messed up network
Date: Tue, 30 Sep 2003 09:13:47 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064927627.65636.9.camel@dlacoste.ottawa.loran.com>
References: <1064865515.8417.2.camel@dlacoste.ottawa.loran.com>
	 <1064889101.1024.27.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1064889101.1024.27.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Honestly, it would keep me happy :)

The linux system is a network management
appliance : it only has one default route
in its configuration, so all other subnets
rely on the redirects to keep traffic down.

So although that would solve the problem, it
could potentially mean a whole lot of duplicated
traffic, which is not something a network management
appliance is supposed to _create_ :)

Dana Lacoste
Ottawa, Canada

On Mon, 2003-09-29 at 22:31, jamal wrote:
> Why dont you just ignore redirects on the Linux machine?
> echo 0 > /proc/sys/net/ipv4/conf/*/accept_redirects
> 
> cheers,
> jamal
> 
> 
