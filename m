From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: sunrpc port allocation and IANA reserved list
Date: Wed, 11 Nov 2009 06:58:10 +0900
Message-ID: <1257890290.3044.39.camel@heimdal.trondhjem.org>
References: <4AF9A63B.6010101@nortel.com>
	 <1257875623.2834.19.camel@achroite.uk.solarflarecom.com>
	 <4AF9B2CF.6050305@nortel.com>
	 <1257884799.3044.7.camel@heimdal.trondhjem.org>
	 <4AF9D5D1.9040501@nortel.com>
	 <1257887844.3044.24.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Linux kernel <linux-kernel@vger.kernel.org>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758461AbZKJV6O@vger.kernel.org>
In-Reply-To: <1257887844.3044.24.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-11-11 at 06:17 +0900, Trond Myklebust wrote:
> The people who are trying to run absolutely all IANA registered services
> on a single Linux machine that is also trying to run as an NFS client
> may have a problem, but then again, how many setups do you know who are
> trying to do that?

BTW: Even these setups can be fixed. One way to extend the available
port ranges is to allocate more than one IP address; either through the
use of multiple NICs, or through address aliasing. You can set up the
services to listen on one interface, while setting up your routing
tables to ensure that any outgoing connections to your NFS servers go
through through a different interface.

You could also use virtualised machines to host the services, etc...

Trond
