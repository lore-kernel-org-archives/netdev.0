From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Wed, 26 Aug 2009 01:11:38 +0200
Message-ID: <20090825231138.GB13630@electric-eye.fr.zoreil.com>
References: <m1skfkrik2.fsf@fess.ebiederm.org> <1250895567.23419.1.camel@obelisk.thedillows.org> <1250897657.23419.5.camel@obelisk.thedillows.org> <m1iqggf4rf.fsf@fess.ebiederm.org> <m18whcf3w2.fsf@fess.ebiederm.org> <1250973787.3582.14.camel@obelisk.thedillows.org> <m1r5v0ogvw.fsf@fess.ebiederm.org> <1251169150.4023.11.camel@obelisk.thedillows.org> <m1ljl77exz.fsf@fess.ebiederm.org> <1251237296.9607.42.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Michael Buesch <mb@bu3sch.de>,
	Rui Santos <rsantos@grupopie.com>,
	Michael B?ker <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932339AbZHYXHy@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1251237296.9607.42.camel@lap75545.ornl.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Dillow <dave@thedillows.org> :
[...]
> I wouldn't object if you did it, but I don't have time for it right now.
> And it may make Francois's life harder when he does his periodic sweep
> of the vendor driver, looking for differences.

This part of Realtek's driver(s) is not too tricky (I wonder if some code is
there by design or accident but it is a different story).

I do not feel safe with the TxDescUnavail bit : the driver does not
explicitely do anything to handle it but the behavior of the driver
can change depending on it. :o/

-- 
Ueimor
