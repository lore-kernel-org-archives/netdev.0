From: "Chad N. Tindel" <chad@tindel.net>
Subject: Re: Wrong UIDs reported in /proc/net/tcp
Date: Tue, 9 Nov 2004 17:41:20 -0500
Message-ID: <20041109224120.GA87321@calma.pair.com>
References: <20041109205358.GA64015@calma.pair.com> <Pine.LNX.4.33.0411091309450.16316-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: akepner@sgi.com
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0411091309450.16316-100000@localhost.localdomain>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The following may be of interest:
> 
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=44854

This isn't really the same issue.  This looks like an euid vs. uid problem
that reproduces every time.  

The problem we are seeing is a timing-window-race-condition kind of problem
that happens maybe 1 in 100,000 times.

Chad
