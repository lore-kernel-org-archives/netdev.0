From: "Sean Hefty" <sean.hefty@intel.com>
Subject: RE: [PATCH 2/5] [RFC] Infiniband: connection
	abstraction
Date: Tue, 17 Jan 2006 15:51:23 -0800
Message-ID: <ORSMSX401eBBsQwY6YH00000044@orsmsx401.amr.corp.intel.com>
References: <20060117153838.3dc2cd2e@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: "'Stephen Hemminger'" <shemminger@osdl.org>
In-Reply-To: <20060117153838.3dc2cd2e@dxpl.pdx.osdl.net>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

>> +static void cm_mask_compare_data(u8 *dst, u8 *src, u8 *mask)
>
>static void cm_mask_compare_data(u8 *dst, const u8 *src, u8 *mask)
>
>but I would rename it to cm_mask_copy since it doesn't really do a compare.

I'll change this.  The function is masking the "data to use in the comparison",
but I can see the confusion.

>> +static int cm_compare_data(struct ib_cm_private_data_compare *src_data,
>> +			   struct ib_cm_private_data_compare *dst_data)
>
>static int cm_compare_data(const struct ib_cm_private_data_compare *src,
>		           cosnt struct ib_cm_private_data_compare *dst)
>Your data type names are getting too long ^^^^^^^^^^^^^^^^^^^^^^^^

I'll fix.

Thanks for the comments.

- Sean
