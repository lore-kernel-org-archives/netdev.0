From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/7] netfilter: nf_ct_helper: implement variable length
 helper private data
Date: Mon, 04 Jun 2012 06:09:59 -0700
Message-ID: <1338815399.8574.10.camel@joe2Laptop>
References: <1338812485-4232-1-git-send-email-pablo@netfilter.org>
	 <1338812485-4232-4-git-send-email-pablo@netfilter.org>
	 <alpine.LNX.2.01.1206041456480.16684@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1206041456480.16684@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-04 at 15:06 +0200, Jan Engelhardt wrote:
> On Monday 2012-06-04 14:21, pablo@netfilter.org wrote:

> >@@ -218,13 +221,13 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, struct nf_conn *tmpl,
> > 	}
> > 
> > 	if (help == NULL) {
> >-		help = nf_ct_helper_ext_add(ct, flags);
> >+		help = nf_ct_helper_ext_add(ct, helper, flags);
> > 		if (help == NULL) {
> > 			ret = -ENOMEM;
> > 			goto out;
> > 		}
> > 	} else {
> >-		memset(&help->help, 0, sizeof(help->help));
> >+		memset(&help->data, 0, sizeof(helper->data_len));
> > 	}
> 
> memset(help->data, 0, sizeof(helper->data_len));

	memset(help->data, 0, helper->data_len);


