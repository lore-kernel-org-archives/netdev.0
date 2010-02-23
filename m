From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Tue, 23 Feb 2010 18:09:41 -0500
Message-ID: <1266966581.3973.675.camel@bigi>
References: <4B4F24AC.70105@trash.net> <1263481549.23480.24.camel@bigi>
	 <4B4F3A50.1050400@trash.net> <1263490403.23480.109.camel@bigi>
	 <4B50403A.6010507@trash.net> <1263568754.23480.142.camel@bigi>
	 <m13a0tf17t.fsf@fess.ebiederm.org> <1266875729.3673.12.camel@bigi>
	 <m1wry46es9.fsf@fess.ebiederm.org> <1266931623.3973.643.camel@bigi>
	 <m1iq9ocafv.fsf@fess.ebiederm.org> <1266934817.3973.654.camel@bigi>
	 <m1r5obbu2w.fsf@fess.ebiederm.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Ben Greear <greearb@candelatech.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <m1r5obbu2w.fsf@fess.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-02-23 at 12:00 -0800, Eric W. Biederman wrote:

> That point of the mount to hold a persistent reference to the
> namespace without using a process.
> 
> The point of the of the to be written set_ns call is to change
> the default network namespace of the process such that all future
> open/bind/socket calls happen in the referenced network namespace.

Ok, i like it ;-> Patches RSN? Let me if you want someone to test..

> The are a few stray places like sysfs where it is the mount point
> not current->nsproxy->net_ns that will determine what we see.

Is sysfs considered "usable enough" for namespaces?

> Attributes of the specific namespace?

Well, example what is being un/shared etc. 

cheers,
jamal


