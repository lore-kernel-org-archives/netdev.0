From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 0/3] Make vhost multi-threaded and associate each thread to
 its guest's cgroup/cpumask
Date: Tue, 18 May 2010 17:04:38 -0700
Message-ID: <1274227478.2370.106.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following set of patches create a new API to associate a
workqueue to the current thread's cgroup and cpumask.
This API is used by multi-threaded vhost to associate each
thread to the corresponding guest's cgroup and cpumask.

Thanks
Sridhar
