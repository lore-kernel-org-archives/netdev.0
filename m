From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 1/5] mips: Set CONFIG_NET=y in defconfigs
Date: Tue, 23 Sep 2014 18:06:04 +0200
Message-ID: <54219A6C.7000407@suse.cz>
References: <54218AEF.5090200@suse.cz>  <1411487044-14071-1-git-send-email-mmarek@suse.cz> <20140923.120237.1788295912902036193.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, rdunlap@infradead.org,
        netdev@vger.kernel.org, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-kbuild@vger.kernel.org,
        linux-mips@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20140923.120237.1788295912902036193.davem@davemloft.net>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On 2014-09-23 18:02, David Miller wrote:
> From: Michal Marek <mmarek@suse.cz>
> Date: Tue, 23 Sep 2014 17:44:00 +0200
> 
>> Commit 5d6be6a5 ("scsi_netlink : Make SCSI_NETLINK dependent on NET
>> instead of selecting NET") removed what happened to be the only instance
>> of 'select NET'. Defconfigs that were relying on the select now lack
>> networking support.
>>
>> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>> Cc: linux-mips@linux-mips.org
>> Signed-off-by: Michal Marek <mmarek@suse.cz>
> 
> On the contrary, since NET was being selected for them indirectly
> previously, weren't they depending instead upon NET being enabled?
> 
> Likewise for SCSI_NETLINK, SCSI_FC_ATTRS, and whatever was triggering
> the select upon them?

They have SCSI_FC_ATTRS=y/m and were relying on the select statements
turning this into SCSI_NETLINK=y and CONFIG_NET=y.

Michal
