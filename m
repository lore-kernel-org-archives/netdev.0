From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: ARGH MORE BUGS!!!
Date: Mon, 21 Feb 2005 21:28:54 +0100
Message-ID: <20050221202854.GA26248@electric-eye.fr.zoreil.com>
References: <421A3EB8.4050607@rapidforum.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Christian Schmid <webmaster@rapidforum.com>
Content-Disposition: inline
In-Reply-To: <421A3EB8.4050607@rapidforum.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christian Schmid <webmaster@rapidforum.com> :
[...]
> But now I hit another BUG: After I have managed to create 4500 sockets, 10 
> minutes later an interesting phenomenon appeared: It locks for 5 seconds 
> every 60 seconds. I first thought this was something in my program but I 
> can do what I want, I wasn't able to fix this. Even a restart of my program 
> didnt help. It even appears with 400 connections. Then I despairedly just 
> restarted the system and: It was gone. So what is THIS?

What about monitoring /proc/slabinfo and vmstat output (with heavy renicing) ?

--
Ueimor
