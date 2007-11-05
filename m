From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/4] Distributed storage. Squizzed black-out of the dancing back-aching hippo.
Date: Mon, 5 Nov 2007 21:41:56 +0300
Message-ID: <20071105184155.GA26175@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

I'm pleased to announce 7'th and the final release of the distributed
storage subsystem (DST). It allows to form a storage on top of local and
remote nodes and combine them in linear or mirroring setup, which in
turn can be exported to remote nodes.

Short changelog:
* added strong checksum support (Castagnoli crc)
* extended autoconfiguration (added ability to request if remote
	side supports strong checksum and turn it on if needed)
* documentation addon - sysfs files
* added clean/dirty sysfs files which allows to mark
	node as clean (sinc) or dirty (not sync)
* fair number of bug fixes (including really tricky
	bastards, which are unlikely to be found in real
	setups, but which were still bugs)
* and the main one - added release name (it clearly shows my condition)

Overall list of features of the DST can be found on project's homepage:

http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst

Thank you.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>


-- 
	Evgeniy Polyakov
