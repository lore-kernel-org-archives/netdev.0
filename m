From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: PATCH Re: udp weirdness
Date: Wed, 02 Oct 2002 10:09:24 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3D9AFE14.4030606@nortelnetworks.com>
References: <3D99B6C7.3010302@nortelnetworks.com> <200210011531.TAA19943@sex.inr.ac.ru> <20021002111326.GG357@hookipa>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, hadi@cyberus.CA, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <Eric.Lemoine@ens-lyon.fr>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Lemoine wrote:

> Would you mind explaining a bit more why apps will lockup if we block
> after select() succeeded. Or anyone?

I suspect he means a temporary lockup.

There are many apps that use blocking sockets and rely on select() to 
tell them when they may write out to the socket without blocking.

If the write then blocks, the whole app is blocked.  Some of them 
probably wouldn't like this.

Was that it Alexey? Or is there something more that I missed?

Chris
