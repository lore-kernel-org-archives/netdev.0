From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: TCP IP Offloading Interface
Date: Sun, 13 Jul 2003 12:58:01 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3F118F99.1020104@pobox.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>	 <20030713004818.4f1895be.davem@redhat.com>  <52u19qwg53.fsf@topspin.com> <1058113895.554.7.camel@dhcp22.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@topspin.com>,
	"David S. Miller" <davem@redhat.com>,
	Alan Shih <alan@storlinksemi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1058113895.554.7.camel@dhcp22.swansea.linux.org.uk>
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> Finally if you are streaming objects by non mapped references (eg
> sendfile or see LM's paper from long ago on splice()) then the problem
> goes away.


As an aside, I really like sendfile's semantics except for

* People occasionally want to add a receivefile(2).  I disagree... 
sendfile(2) interface should be really be considered a universal 
"fdcopy" interface, regardless of what the 'to' and 'from' file 
descriptors are attached to.  File to socket.  Socket to file.  File to 
file.  socket to socket.  All should be supported, even if the fallback 
is a stupid (but small!) in-kernel copy loop.

* Copy-until-EOF semantics are either undefined, or, unclear to me 
personally.

	Jeff



