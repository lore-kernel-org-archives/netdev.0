From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: net/sctp/sm_make_chunk.c alignment problems on parisc64
Date: Fri, 12 Sep 2003 13:46:28 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030912164628.GF8713@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>,
   lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Latest 2.6 bk tree, but I think this is hanging there for quite a while.

CC [M]  net/sctp/sm_make_chunk.o
{standard input}: Assembler messages:
{standard input}:2386: Error: Field not properly aligned [8] (52).
{standard input}:2386: Error: Invalid operands
{standard input}:2398: Error: Field not properly aligned [8] (52).
{standard input}:2398: Error: Invalid operands
make[2]: *** [net/sctp/sm_make_chunk.o] Error 1
make[1]: *** [net/sctp] Error 2
make: *** [net] Error 2

it happens in the sctp_pack_cookie function.

- Arnaldo
