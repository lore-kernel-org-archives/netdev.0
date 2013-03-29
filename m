From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [BUG] Crash with NULL pointer dereference in bond_handle_frame
 in -rt (possibly mainline)
Date: Fri, 29 Mar 2013 15:55:13 -0400
Message-ID: <1364586913.10629.40.camel@gandalf.local.home>
References: <1364490997.6345.237.camel@gandalf.local.home>
	 <1364491792.15753.47.camel@edumazet-glaptop>
	 <20130329094856.GB1677@minipsycho.orion>
	 <1364582184.10629.34.camel@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Guy Streeter <streeter@redhat.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>, stephen@networkplumber.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364582184.10629.34.camel@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-03-29 at 14:36 -0400, Steven Rostedt wrote:

This one's for you Paul ;-)

That means Eric's solution fits perfectly well here.

	< system in single state : everyone sees cat = alive >

	insert_into_box(cat);

	< system in dual state : new calls see cat == dead, but
	  current calls see cat == alive >

	open_box();

	< system is back to single state: everyone sees cat = dead >

	funeral(cat); 

no problem ;-)

-- Steve
