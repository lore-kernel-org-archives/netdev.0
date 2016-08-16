From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Aug 16 (mellanox/mlx5 &
	sound/oss/)
Date: Tue, 16 Aug 2016 08:26:52 -0700
Message-ID: <c5f1449f-b1fb-37be-71c1-85691d34994e@infradead.org>
References: <20160816140121.5b89f2a0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 moderated for non-subscribers <alsa-devel@alsa-project.org>,
 linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20160816140121.5b89f2a0@canb.auug.org.au>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

On 08/15/16 21:01, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20160815:
> 

on i386:

sound/built-in.o:(.data+0x5c): multiple definition of `dev_list'
drivers/built-in.o:(.data+0x6aee8): first defined here
ld: Warning: size of symbol `dev_list' changed from 8 in drivers/built-in.o to 16 in sound/built-in.o


sound/ is an old oss driver (soundcard.c):

struct oss_minor_dev {
	unsigned short minor;
	unsigned int enabled;
} dev_list[] = {
	{ SND_DEV_DSP16 },
	{ SND_DEV_AUDIO },
};

=====

drivers/ is net/ethernet/mellanox/mlx5/core/mlx5_core.h:

extern struct list_head dev_list;




-- 
~Randy
