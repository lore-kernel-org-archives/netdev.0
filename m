From: Megh Bhatt <megh.bhatt@gmail.com>
Subject: Question about Linux routing - ip_route_output_key vs fib_lookup
Date: Wed, 16 Feb 2005 12:35:57 -0500
Message-ID: <5d1f895705021609356e34aeec@mail.gmail.com>
Reply-To: Megh Bhatt <megh.bhatt@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I had a question about Linux routing functions, suppose I want to find
out what interface does a route to an IP address belong to - is it
better (in terms of performance) to use ip_route_output_key or
fib_lookup. My initial guess from looking at the source code is
fib_lookup since the routing cache wont be helpful since I wont have
any interface information (rather want to find out interface
information) but wanted to be sure. Thanks.

Megh
