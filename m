From: Eran Mann <emann@mrv.com>
Subject: Re: [patch 2.4] kernel oops on VLAN removal
Date: Wed, 20 Aug 2003 15:51:51 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F436EE7.1030104@mrv.com>
References: <3F424405.6020002@mrv.com> <20030819124154.75ec0383.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819124154.75ec0383.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 19 Aug 2003 18:36:37 +0300
> Eran Mann <emann@mrv.com> wrote:
> 
> 
>>The current code attempts to add a proc entry for each vlan device,
>>however there is no check whether this attempt succeeded. When a device
>>is unregistered it tries to remove the proc entry, if none was added
>>the oops follows...
> 
> 
> Patch applied to my 2.4.x tree, scheduled for 2.4.23-preX
> 
> Can someone check out 2.6.x?
> 
It looks the same in 2.6.0-test3. The patch applies (with small offsets) 
and works (the oops is much harder to trigger in 2.6.x since 
PROC_NDYNAMIC is increased to 16384, I had to reduce it to 4096 to 
trigger the oops).

-- 
Eran Mann
Senior Software Engineer
MRV International
Tel: 972-4-9936297
Fax: 972-4-9890430
www.mrv.com
