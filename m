From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH 0/2] net/mlx4_core: clean up two functions
Date: Tue, 07 Jan 2014 14:00:22 +0100
Message-ID: <1389099622.15032.18.camel@x41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Rony Efraim <ronye@mellanox.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

0) These two patches are very similar. They both clean up a function to
help GCC understand the codeflow. Both help silence a warning.

1) Compile tested only (on 32 bits x86). I do not have this hardware.

2) Please note that there's no MAINTAINERS entry for mlx4_core. (Neither
is there an entry for the MLX4 IB driver.) Shouldn't it be added? 

Paul Bolle (2):
  net/mlx4_core: clean up cq_res_start_move_to()
  net/mlx4_core: clean up srq_res_start_move_to()

 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 96 ++++++++--------------
 1 file changed, 35 insertions(+), 61 deletions(-)

-- 
1.8.4.2
