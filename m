From: Nir Tzachar <tzachar@cs.bgu.ac.il>
Subject: Re: network protocol query
Date: Sun, 14 Nov 2004 09:41:23 +0200 (IST)
Message-ID: <Pine.LNX.4.50.0411140936040.15336-100000@nexus.cs.bgu.ac.il>
References: <20041114030157.88091.qmail@web41406.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "" <kernelnewbies@nl.linux.org>
Return-path: <kernelnewbies-bounce@nl.linux.org>
To: cranium2003 <cranium2003@yahoo.com>
In-Reply-To: <20041114030157.88091.qmail@web41406.mail.yahoo.com>
Sender: kernelnewbies-bounce@nl.linux.org
Errors-to: kernelnewbies-bounce@nl.linux.org
List-help: <mailto:ecartis@nl.linux.org?Subject=help>
List-unsubscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=unsubscribe>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:kernelnewbies-request@nl.linux.org?Subject=subscribe>
List-owner: <mailto:ecartis-owner@nl.linux.org>
List-post: <mailto:kernelnewbies@nl.linux.org>
List-archive: <http://mail.nl.linux.org/kernelnewbies/>
List-Id: netdev.vger.kernel.org

> hello,
> kernel. Is there any function in kernel that help me
> to add new protocol?can it be working with existing

try looking at existing protocols, and how the register themselves.
you basically need to inet_add_protocol to add your protocol, after you 
built the proper struct net_protocol.

hope this helped.


-- 
========================================================================
nir.

--
Kernelnewbies: Help each other learn about the Linux kernel.
Archive:       http://mail.nl.linux.org/kernelnewbies/
FAQ:           http://kernelnewbies.org/faq/
