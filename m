From: "John S. Denker" <jsd@monmouth.com>
Subject: Re: defending against syn flood attacks
Date: Tue, 01 Apr 2003 15:58:52 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E89FD8C.2060607@monmouth.com>
References: <Pine.LNX.4.44.0304012156390.22941-100000@laptop1.agatha>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Oskar Andreasson <blueflux@koffein.net>
In-Reply-To: <Pine.LNX.4.44.0304012156390.22941-100000@laptop1.agatha>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 04/01/2003 02:59 PM, Oskar Andreasson wrote:
>>   
>> TCP syncookies "seriously violates the TCP protocol" 
 >> ... statement written by Alexey.

Those who are interested in defending against
syn flood attacks without seriously violating the
TCP protocol may be interested in the following:


                Abstract

The protocol of the present invention includes two new
first level protocols and several embodiments of a
second level protocol. The two new first level protocols
of the present invention include the TCP2B protocol and
the TCP2E protocol. In the TCP2B protocol, both client
and server indicate their support for this protocol using
one or more bits in TCP header. According to the
TCP2B protocol, the client retransmits its requested
options in the ACK message so the server need not
store the options after the connection request. In the
TCP2E protocol, the server maintains a Friends Table
listing addresses of device recently observed to be
complying with TCP. If a client's address is on the
Friends Table, the connection request is processed
according to TCP. Otherwise, the server sends an ACK
message to the client to prompt the client to send a
reset message. The client's address can then be added
to the Friends Table.

The patent is held by AT&T.  I have no idea how hard it
would be to get a license.

http://patft.uspto.gov/netacgi/nph-Parser?Sect1=PTO1&Sect2=HITOFF&d=PALL&p=1&u=/netahtml/srchnum.htm&r=1&f=G&l=50&s1=5,958,053.WKU.+5,958,053.WKU.&OS=PN/5,958,053+OR+PN/5,958,053&RS=PN/5,958,053+OR+PN/5,958,053
