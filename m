From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: asymmetry with MSG_DONTWAIT in sendmsg() and recvmsg()
Date: Thu, 08 Jul 2004 14:34:36 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40ED93BC.1060901@nortelnetworks.com>
References: <40ED8399.2040907@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael T Kerrisk <mtk-lists@gmx.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <40ED8399.2040907@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Nivedita Singhvi wrote:
> Chris Friesen wrote:
>  > Michael T Kerrisk wrote:
>  >
>  >> MSG_DONTWAIT should also work with recvmsg().
>  >
>  >
>  > Hmm...  Just tried it with a DGRAM socket, and it seems to work.  Any
>  > ideas why its not in the man pages?
> 
> Think you are on an older version of the man pages.
> It's been there for a while.

It's mentioned in the "msg_flags" section, which is set on call *return*.  It's 
not mentioned in the "flags" section.

Perhaps its just in the wrong part of the man page...

Chris
