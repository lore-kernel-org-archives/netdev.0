From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH] sctp: integer overflow in sctp_auth_create_key()
Date: Tue, 29 Nov 2011 14:24:01 -0500
Message-ID: <A1A6AF9D-8C35-4702-9693-7BCBEDE27219@gmail.com>
References: <426D7BA8-ECD0-44D6-A09F-2033F0C825FC@gmail.com> <4ED3AC7D.6090108@hp.com> <147F953A-CC69-41FF-ACD4-64E5E2956411@gmail.com> <4ED4F428.9030807@hp.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org
To: Vladislav Yasevich <vladislav.yasevich@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4ED4F428.9030807@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for clarifying this!

I will leave the check there and incorporate your comments into a new patch.

- xi

On Nov 29, 2011, at 10:03 AM, Vladislav Yasevich wrote:
> 
> That should be ok as well.  There is an overflow guard in the api
> entry point so that should guard against overflows from user space.
> 
> On the network end I miscalculated a little.  The key is actually made up
> of user_key (1 short) + 2 * key_vector (3 shorts) for a total of 7*MAX_USHORT;
> however, that still will not overflow 32 bits.
> 
> -vlad
