From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH net-next 1/2] socket: Allow external sockets to use
 socket syscalls
Date: Fri, 26 Dec 2014 19:56:50 +0000
Message-ID: <20141226195650.GF22149@ZenIV.linux.org.uk>
References: <1419576624-8999-1-git-send-email-agartrell@fb.com>
 <1419576624-8999-2-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: Alex Gartrell <agartrell@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1419576624-8999-2-git-send-email-agartrell@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 25, 2014 at 10:50:23PM -0800, Alex Gartrell wrote:
> Currently the "is-socket" test for a file compares the ops table pointer,
> which is static and local to the socket.c.  Instead, this adds a flag for
> private_data_is_socket.  This is an exceptionally long commit message for a
> two-line patch.

NAK.  Don't crap into struct file, please.
