From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/3] RDS: Re-add pf/sol access via sysctl
Date: Tue, 07 Apr 2015 14:59:44 -0400 (EDT)
Message-ID: <20150407.145944.1195581092246069241.davem@davemloft.net>
References: <cover.1428150441.git.sowmini.varadhan@oracle.com>
	<cover.1428150441.git.sowmini.varadhan@oracle.com>
	<b6c3a9a81f4ef47d6c0fe69dee6d0f1b12a419db.1428150441.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chien.yen@oracle.com, rds-devel@oss.oracle.com, agrover@redhat.com,
	clm@fb.com, zab@zabbo.net, ajaykumar.hotchandani@oracle.com,
	sergei.shtylyov@cogentembedded.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b6c3a9a81f4ef47d6c0fe69dee6d0f1b12a419db.1428150441.git.sowmini.varadhan@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sat,  4 Apr 2015 08:45:44 -0400

> Although RDS has an official PF_RDS value now, existing software
> expects to look for rds sysctls to determine it. We need to maintain
> these for now, for backwards compatibility.
> 
> Original patch by Andy Grover
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Cc: Ajaykumar Hotchandani <ajaykumar.hotchandani@oracle.com>

If these never existed before, this is a feature patch and is not appropriate
for 'net'.

If they did exist before and were mistakenly removed, you need to provide
a proper "Fixes: " tag showing what commit introduced the problem.
