From: John Heffner <jheffner@psc.edu>
Subject: Re: tcp_mem setting bytes or memory pages
Date: Tue, 24 May 2005 13:09:38 -0400
Message-ID: <200505241309.38771.jheffner@psc.edu>
References: <20050524125951.C11337@cs.yorku.ca>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Griffith <paulg@cs.yorku.ca>
In-Reply-To: <20050524125951.C11337@cs.yorku.ca>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 24 May 2005 12:59 pm, Paul Griffith wrote:
> Greetings,
>
> I have been searching the Internet for a final answer what the values
> in net.ipv4.tcp_mem mean.
>
> I have seen some sites say it is in memory pages (4K blocks) and other
> have said it is in KB. What the real answer?

It's in pages, as described in Documentation/networking/ip-sysctl.txt.  A lot 
of people have this wrong.  If you find any incorrect sites, could you point 
them out or send mail to their maintainers?  I've gotten a few corrected that 
I've noticed so far.

  -John
