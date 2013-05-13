From: "Jongsung Kim" <neidhard.kim@lge.com>
Subject: RE: [PATCH v2 4/4] net: phy: realtek: cleanup code
Date: Mon, 13 May 2013 11:48:35 +0900
Message-ID: <017801ce4f84$5d423320$17c69960$@lge.com>
References: <201305081910.27203.neidhard.kim@lge.com> <1368170967-20589-4-git-send-email-neidhard.kim@lge.com> <518CD784.1030709@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <peppe.cavallaro@st.com>,
	<chohnstaedt@innominate.com>, <timur@freescale.com>,
	<heiko.carstens@de.ibm.com>, <schwidefsky@de.ibm.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "'Sergei Shtylyov'" <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <518CD784.1030709@cogentembedded.com>
Content-Language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> :
>> -		.suspend	= genphy_suspend,
>> -		.resume		= genphy_resume,
>> +		.suspend	= &genphy_suspend,
>> +		.resume		= &genphy_resume,
>
>    Contrariwise, you should have dropped & from the other functions. 
>It's completely superfluous.
>

Agreed. Thank you  for your comment, Sergei.
