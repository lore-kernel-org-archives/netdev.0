From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][UPDATED PATCH 2.6.16] [Patch 9/9] Generic netlink
	interface for delay accounting
Date: Sun, 26 Mar 2006 09:05:18 -0500
Message-ID: <1143381918.5184.52.camel@jzny2>
References: <1142303607.24621.63.camel@stark>
	 <1143122686.5186.27.camel@jzny2> <20060323154106.GA13159@in.ibm.com>
	 <1143209061.5076.14.camel@jzny2> <20060324145459.GA7495@in.ibm.com>
	 <1143249565.5184.6.camel@jzny2> <20060325094126.GA9376@in.ibm.com>
	 <1143291133.5184.32.camel@jzny2> <20060325153632.GA25431@in.ibm.com>
	 <1143308901.5184.48.camel@jzny2>
	 <661de9470603251022w7f8991e9g73d70a65f5d475ea@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Helsley <matthltc@us.ibm.com>,
	Shailabh Nagar <nagar@watson.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751205AbWCZOFh@vger.kernel.org>
To: balbir@in.ibm.com
In-Reply-To: <661de9470603251022w7f8991e9g73d70a65f5d475ea@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-25-03 at 23:52 +0530, Balbir Singh wrote:


> No, we cannot have both passed. If we pass both a PID and a TGID and
> then the code returns just the stats for the PID.
> 

ok, that clears it then; i think you are ready to go.

> >
> > Also in regards to the nesting, isnt there a need for nla_nest_cancel in
> > case of failures to add TLVs?
> >
> 
> I thought about it, but when I looked at the code of genlmsg_cancel()
> and nla_nest_cancel().  It seemed that genlmsg_cancel() should
> suffice.
> 

If your policy is to never send a message if anything fails, then you
are fine.

What would be really useful now that you understand this, is if you can
help extending/cleaning the document i sent you. Or send me a table of
contents of how it would have flowed better for you.

cheers,
jamal
