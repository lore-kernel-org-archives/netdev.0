From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Fri, 03 Jan 2003 20:18:00 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E163648.2040204@pobox.com>
References: <20030103164001.S48623@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Donald Becker <becker@scyld.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030103164001.S48623@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> Some programs require ability to accept packets destined to certain
> MAC addresses (in addition to their own).
> Example Jerome Ettienes vrrpd (http://w3.arobas.net/~jetienne/vrrpd/)
> 
> The trick is to add unicast addresses via SIOCADDMULTI and accept those
> packets when they make their way up the stack.
> I think this used to work, no? Donald, any history/comments behind
> this?


Over and above Donald's comments, from an interface perspective I think 
this is a bit of a hack, don't you?  :)  Calling an "add-multi" ioctl 
should do precisely that... and only that :)
