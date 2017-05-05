From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Question about SOCK_SEQPACKET
Date: Fri, 5 May 2017 11:21:02 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE60CD@AcuExch.aculab.com>
References: <CAGtMfeCt95bj3-J5+TNb5gxVJUBDrgRjMXqMz-3jk9cOh0Z=tA@mail.gmail.com>
 <af19f11a-1bc3-bb8f-faf6-65c11b632bbf@redhat.com>
 <20170505100926.GD1547@oracle.com>
 <e413b04e-b441-604c-f605-c5a28389d064@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Sam Kumar <samkumar99@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Steven Whitehouse' <swhiteho@redhat.com>,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e413b04e-b441-604c-f605-c5a28389d064@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse
> Sent: 05 May 2017 11:34
...
> Just before the part that you've quoted, the description for
> SOCK_SEQPACKET says:
> "The SOCK_SEQPACKET socket type is similar to the SOCK_STREAM type, and
> is also connection-oriented. The only difference between these types is
> that record boundaries are maintained using the SOCK_SEQPACKET type. A
> record can be sent using one or more output operations and received
> using one or more input operations, but a single operation never
> transfers parts of more than one record."

Right SOCK_SEQPACKET is for protocols like ISO transport.
There is no limit on the length of a 'record'.
I've written file transfer programs that put the entire file
data into a single 'record'. The receiver disconnected on
receipt of the 'end of record'.

The socket man pages could easily be wrong - they are very IP-centric.
Remember ISO transport use declined when Unix became more popular
back in the mid 1980s. Unix sockets have never really been used for
it - the address information needed just doesn't match that IP
(especially IPv4).

	David
