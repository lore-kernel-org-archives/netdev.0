From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: TOE brain dump
Date: Tue, 5 Aug 2003 10:15:25 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030805101525.P670@nightmaster.csn.tu-chemnitz.de>
References: <20030804163606.Q639@nightmaster.csn.tu-chemnitz.de> <ODEIIOAOPGGCDIKEOPILEEOCDAAA.alan@storlinksemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Nivedita Singhvi <niv@us.ibm.com>,
	Werner Almesberger <werner@almesberger.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Alan Shih <alan@storlinksemi.com>
Content-Disposition: inline
In-Reply-To: <ODEIIOAOPGGCDIKEOPILEEOCDAAA.alan@storlinksemi.com>; from alan@storlinksemi.com on Mon, Aug 04, 2003 at 10:19:21AM -0700
List-Id: netdev.vger.kernel.org

On Mon, Aug 04, 2003 at 10:19:21AM -0700, Alan Shih wrote:
> So would main processor still need a copy of the data for re-transmission?
> Won't that defeat the purpose?

No, since I didn't state that a retransmission is done along the
pipe, because you cannot go back in a pipeline.

A retransmission can be done at the end of the pipe, where this
can also be done in hardware.

Regards

Ingo Oeser
