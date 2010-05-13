From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 1/9] mm: add generic adaptive large memory allocation APIs
Date: Thu, 13 May 2010 22:49:26 +0800
Message-ID: <AANLkTilanD4PlDpLqtTK7uE5o4aPgLhhYvYvVI37GycU@mail.gmail.com>
References: <1273744285-8128-1-git-send-email-xiaosuo@gmail.com>
	<1273761576_4060@mail4.comsite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Roland Dreier <rolandd@cisco.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Divy Le Ray <divy@chelsio.com>,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
	"Theodore Ts'o" <tytso@mit.edu>, Andreas Dilger <adilger@sun.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Paul Menage <menage@google.com>,
	Li Zefan <lizf@cn.fujitsu.com>, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-ext4@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	containers@lists.linux-foundation.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Peter Zijlstra <peterz@infradead.org>
To: Milton Miller <miltonm@bga.com>
Return-path: <linux-ext4-owner@vger.kernel.org>
In-Reply-To: <1273761576_4060@mail4.comsite.net>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 13, 2010 at 10:39 PM, Milton Miller <miltonm@bga.com> wrote=
:
> On Thu, 13 May 2010 at 17:51:25 +0800, Changli Gao wrote:
>
>> +static inline void *kvcalloc(size_t n, size_t size)
>> +{
>> + =C2=A0 =C2=A0 return __kvmalloc(n * size, __GFP_ZERO);
>>
>
> This needs multiply overflow checking like kcalloc.
>

Thanks.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe linux-ext4" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
