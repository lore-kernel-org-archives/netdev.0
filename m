From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v3 2/7] atm: add owner of push() callback to atmvcc
Date: Wed, 7 Nov 2012 14:05:22 -0500
Message-ID: <20121107140522.257c541c@thirdoffive.cmf.nrl.navy.mil>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
	<1352240222-363-3-git-send-email-krzysiek@podlesie.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Woodhouse <David.Woodhouse@intel.com>,
	davem@davemloft.net
To: Krzysztof Mazur <krzysiek@podlesie.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352240222-363-3-git-send-email-krzysiek@podlesie.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue,  6 Nov 2012 23:16:57 +0100
Krzysztof Mazur <krzysiek@podlesie.net> wrote:

> The atm is using atmvcc->push(vcc, NULL) callback to notify protocol
> that vcc will be closed and protocol must detach from it. This callback
> is usually used by protocol to decrement module usage count by module_put(),
> but it leaves small window then module is still used after module_put().
> 
> Now the owner of push() callback is kept in atmvcc and
> module_put(atmvcc->owner) is called after the protocol is detached from vcc.
> 
> Signed-off-by: Krzysztof Mazur <krzysiek@podlesie.net>

Acked-by: Chas Williams <chas@cmf.nrl.navy.mil>
