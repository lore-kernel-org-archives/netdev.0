From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH] mlx4: Use GFP_NOFS calls during the ipoib TX path when
 creating the QP
Date: Tue, 25 Feb 2014 23:52:45 +0200
Message-ID: <CAJZOPZKYA8Pz1x1cKn46A7+EO+th4DETvmYiX_HR7aYbsfxRRw@mail.gmail.com>
References: <alpine.LNX.2.00.1402211450410.1192@pobox.suse.cz>
	<CAJZOPZK4Ah+nKPWnX3=yM43jbf586GYJ+fh0-OL4bOnqKK8v8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Roland Dreier <roland@kernel.org>, Amir Vadai <amirv@mellanox.com>,
	Eli Cohen <eli@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mel Gorman <mgorman@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJZOPZK4Ah+nKPWnX3=yM43jbf586GYJ+fh0-OL4bOnqKK8v8A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 21, 2014 at 11:53 PM, Jiri Kosina <jkosina@suse.cz> wrote:
>>
>> This was originally a patch from Matthew Finlay <matt@mellanox.com> that
>> addressed a problem whereby NFS writes would enter uninterruptible sleep
>> forever.  The issue happened when using NFS over IPoIB. This is not a
>> recommended configuration as RDMA is preferred but it is still a valid
>> configuration and is important to have in situations where the NFS server
>> does not support RDMA. The problem encountered was described as follows:
>> .



And what happens if you use IPoIB datagram mode, is/why the patch is
needed there?


Also the patch uses a new QP creatiob flag IB_QP_CREATE_USE_GFP_NOFS
but it doesn't
touch include/rdma/ib_verbs.h nor I see this flag defined anywhere on
the patch, does it compile? how?
