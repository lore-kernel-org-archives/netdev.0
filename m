From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/4] DST: Distributed storage.
Date: Mon, 17 Dec 2007 18:03:38 +0300
Message-ID: <11979038181687@2ka.mipt.ru>
References: <20071214133747.GC31971@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:40124 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758249AbXLQPDq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 10:03:46 -0500
In-Reply-To: <20071214133747.GC31971@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Distributed storage.

I'm pleased to announce the 12'th release of the distributed
storage subsystem (DST).

DST allows to form a storage on top of local and remote nodes
and combine them into linear or mirroring setup, which in
turn can be exported to remote nodes.

Short changelog:
 * new improved mirroring algorithm.
	This algorithm uses sliding window approach for full resync
	and write log for partial resync.
 * fixed number of typos and debug cleanups
 * update inode size when linear algorithm changes the size of the
	storage in run time
 * extended number of sysfs files and documentation for them
 * fixed leak in local export node setup
 * name is 'Dancing with the smoked neutrino' now

Overall list of features of the DST can be found on project's homepage:

http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst

DST is also exported as a git tree available for clone and pull from
http://tservice.net.ru/~s0mbre/archive/dst/dst.git

Interested reader can test DST with 2.6.23 tree too
(it should compile fine, but was not tested).

DST passed all FS tests in LTP with XFS (modulo MAX_LOCK_DEPTH too low bug:
[ 8398.605691] BUG: MAX_LOCK_DEPTH too low!
[ 8398.609641] turning off the locking correctness validator.

this is not DST problem though), but it was not performed with
offline/online nodes.

Thank you.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>


