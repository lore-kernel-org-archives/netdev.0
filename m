From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/4] DST: Distributed storage.
Date: Mon, 10 Dec 2007 14:47:29 +0300
Message-ID: <11972872493977@2ka.mipt.ru>
References: <11qqqasdzxczc036@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <11qqqasdzxczc036@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Distributed storage.

I'm pleased to announce the 11'th release of the distributed
storage subsystem (DST). This is a maintenance release and includes
bug fixes and simple feature extensions only.

DST allows to form a storage on top of local and remote nodes
and combine them into linear or mirroring setup, which in
turn can be exported to remote nodes.

Short changelog:
 * wakeup state when mirror detected error to seedup reconnect
 * if connecting in csum mode to no-csum server, do not enable csums
 * do not clean queue until all users are removed
 * allow to increase size of the storage in linear add callback 
	(with this change it is possible to add nodes into linear array
	in real time without stopping storage. Filesystem has to be prepared
	for the case when underlying device has changed its size.
	Real-time addon of mirror nodes is also supported)
 * allow to delete gendisk only after device was started
 * dst debug config option
 * Name: Gamardjoba, genacvale! ('Hi friend' in georgian)

Great thanks to Matthew Hodgson <matthew@mxtelecom.com> for debugging!

Overall list of features of the DST can be found on project's homepage:

http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst

Thank you.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>


