From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: [PATCH][3.13.y-ckt][PATCH 0/1] Backport of mainline commit 4a46b24e for upstream 3.13.y-ckt.
Date: Fri, 27 Feb 2015 15:19:19 -0500
Message-ID: <cover.1424801573.git.joseph.salisbury__7276.67699470675$1425068375$gmane$org@canonical.com>
Cc: alexw@nicira.com, azhou@nicira.com, pshelar@nicira.com,
	davem@davemloft.net, netdev@vger.kernel.org, dev@openvswitch.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: kamal@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A large number of 'failed to flow_del' error messages are being logged in OpenStack deployments running the Ubuntu Trusty release with the 3.13 kernel. This was fixed upstream in the datapath dkms module as well as the 3.16 kernel.  

Commit 4a46b24e is the fix for this issue, and is in mainline as of 3.16-rc6.  However, commit 4a46b24e has a dependency on commit 663efa36 for the define of rcu_dereference_ovsl.

Commit 663efa36 is a clean cherry-pick in upstream 3.13.y-ckt.  However, 4a46b24e required a backport.  Please consider including mainline commit 663efa36 and the backported version of 4a46b24e in the next v3.13.y-ckt release.

The backport for upstream stable 3.14.y is different than for 3.13.y-ckt and I'm not sure if this bug exists in upstream 3.14.  I can send that backport separately if needed.
