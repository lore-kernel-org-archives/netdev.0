From: Donald Becker <becker@scyld.com>
Subject: Re: how to report network device errors to userspace?
Date: Wed, 19 Jun 2002 16:21:48 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0206191616060.1669-100000@presario>
References: <3D10CFF9.B4072FEA@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <3D10CFF9.B4072FEA@nortelnetworks.com>
List-Id: netdev.vger.kernel.org

On Wed, 19 Jun 2002, Chris Friesen wrote:

> I'm curious about the proper way for a network device driver to report
> faults to userspace.

What type of fault?

Errors are counted in /proc/net/dev.

> I haven't been able to find a standard interface for this--does nobody care
> about this kind of thing?

People very much care.  There are sufficient reporting mechanisms for
most errors -- it's much more consistent, orthogonal and thorough than
other device types.  Compare /proc/net/dev with the errors reported for
disks, serial, USB, keyboard...

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
