From: Paul Bolle <pebolle@tiscali.nl>
Subject: iwlwifi: mvm:  BACKPORT_WANT_DEV_COREDUMP?
Date: Fri, 31 Oct 2014 09:40:34 +0100
Message-ID: <1414744834.1964.7.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Valentin Rothberg <valentinrothberg@gmail.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Your commit aadede6e9f4c ("iwlwifi: mvm: port to devcoredump framework")
landed in today's linux-next (next-20141031). It adds a select statement
for BACKPORT_WANT_DEV_COREDUMP. There's no Kconfig symbol 
BACKPORT_WANT_DEV_COREDUMP so this select is currently a nop. (In
https://lkml.org/lkml/2014/9/30/578 I proposed a patch that emits a
warning in cases like this.)

Did you perhaps meant to select WANT_DEV_COREDUMP? Or is the Kconfig
symbol BACKPORT_WANT_DEV_COREDUMP queued somewhere?


Paul Bolle
