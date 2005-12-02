From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: Data corruption when using TCP sockets
Date: Fri, 2 Dec 2005 09:26:25 -0500
Message-ID: <20051202142625.GA12152@kvack.org>
References: <Pine.LNX.4.58.0512021638130.3304@fileserver.nmsworks.co.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: madanagopal <madan@nmsworks.co.in>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0512021638130.3304@fileserver.nmsworks.co.in>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That kernel is beyond ancient -- a 2.4.9 errata kernel was released on 
the day that Red Hat 7.2 shipped.  It is known buggy and superceeded by 
many kernels with substantial bugfixes.

		-ben

On Fri, Dec 02, 2005 at 05:05:28PM +0530, madanagopal wrote:
> hai,
>    We have a socket application in C which connects to a Java application 
> through TCP sockets. We use read() system call to read from the socket. 
> The Java application sends more than 20000 bytes of data sometimes. In the 
> C program, we read those bytes as Type,Length,Value fields where a 
> separate read() call is used for each field. This sometimes creates a data 
> corruption while it works other times.
>    We observe that the first 16384 bytes get read properly. Extra byte or 
> bytes get added in the 16385 th location and this shifts the bytes from 
> 16385 onwards. Because of this our C program gets confused and we are 
> forced to reopen the socket. This is not predictable. Suddenly this 
> problem occurs. Is this an already known issue and if so what 
> is it? How to solve it?
>    We are running both the applications in the same machine which runs 
> Red Hat Linux release 7.2 and its kernel version is 2.4.7-10
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
"You know, I've seen some crystals do some pretty trippy shit, man."
Don't Email: <dont@kvack.org>.
